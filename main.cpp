#include <QCoreApplication>
#include <QDate>
#include <QDateTime>
#include <QElapsedTimer>
#include <QHash>
#include <QTime>
#include <QFile>
#include <QGuiApplication>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QTimer>
#include <QVariantMap>
#include <QGyroscope>
#include <QGyroscopeReading>
#include <QDebug>
#include <QImage>
#include <QFont>
#include <cmath>

class TicketController final : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString word READ word NOTIFY ticketChanged)
    Q_PROPERTY(QString colour READ colour NOTIFY ticketChanged)
    Q_PROPERTY(QString currentTime READ currentTime NOTIFY clockChanged)
    Q_PROPERTY(QString remainingTime READ remainingTime NOTIFY clockChanged)
    Q_PROPERTY(qreal gyroRotation READ gyroRotation NOTIFY gyroRotationChanged)
public:
    TicketController(QObject *parent = nullptr) : QObject(parent) {
        const QString path = ":/qt/qml/BusPaszt/sample.json"; //QCoreApplication::applicationDirPath()
        QFile file(path);
        if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            QJsonParseError error;
            const QJsonDocument document = QJsonDocument::fromJson(file.readAll(), &error);
            if (error.error == QJsonParseError::NoError && document.isArray()) {
                m_records = document.array();
            } else {
                qWarning() << "Invalid sample.json:" << error.errorString();
            }
        } else {
            qWarning() << "Cannot open" << path;
        }
        // Original HTML displays a 24-hour ticket countdown from initial load.
	// Set expiry to 1 day
        m_expiresAt = QDateTime::currentDateTime().addDays(1);
        updateTicket();
        updateClock();
        connect(&m_clock, &QTimer::timeout, this, [this] {
            if (QDate::currentDate() != m_lastDate) updateTicket();
            updateClock();
        });
        m_clock.start(1000);
	// Connect gyroscope reading event to m_gyroRotation
        connect(&m_gyroscope, &QGyroscope::readingChanged, this, [this] {
            const auto *reading = m_gyroscope.reading();
            if (!reading) return;
            // Gyroscope measures angular velocity in degrees/second.
            const qint64 now = m_motionTimer.elapsed();
            if (m_lastMotionMs >= 0) {
                const qreal dt = qMin(qreal(now - m_lastMotionMs) / 1000.0, 0.2);
                m_gyroRotation = std::remainder(m_gyroRotation + reading->z() * dt, 360.0);
                emit gyroRotationChanged();
            }
            m_lastMotionMs = now;
        });
        m_motionTimer.start();
	// Set data rate to 60herz
	m_gyroscope.setDataRate(60);
        if (m_gyroscope.start())
            qWarning() << "Gyroscope could not be started";
    }
    QString word() const { return m_word; }
    QString colour() const { return m_colour; }
    QString currentTime() const { return m_currentTime; }
    QString remainingTime() const { return m_remainingTime; }
    qreal gyroRotation() const { return m_gyroRotation; }
signals:
    void ticketChanged();
    void clockChanged();
    void gyroRotationChanged();
private:
    void updateTicket() {
        m_lastDate = QDate::currentDate();
        const int day = m_lastDate.dayOfYear();
        static const QHash<QString, QString> colours {
            {QStringLiteral("Orange"), QStringLiteral("#F9A03C")},
            {QStringLiteral("Blue"), QStringLiteral("#009BDE")},
            {QStringLiteral("Green"), QStringLiteral("#44CF8C")},
            {QStringLiteral("Pink"), QStringLiteral("#EA427D")},
            {QStringLiteral("Grey"), QStringLiteral("#B3BAC0")}
        };
        m_word = QStringLiteral("Sample");
        m_colour = QStringLiteral("#009BDE");
        for (const QJsonValue &value : m_records) {
            if (!value.isObject()) continue;
            const QJsonObject record = value.toObject();
            if (record.value(QStringLiteral("day")).toInt(-1) != day) continue;
            m_word = record.value(QStringLiteral("word")).toString(m_word);
            const QString key = record.value(QStringLiteral("colour")).toString();
            m_colour = colours.value(key, m_colour);
            break;
        }
        emit ticketChanged();
    }
    void updateClock() {
        m_currentTime = QTime::currentTime().toString(QStringLiteral("HH:mm"));
        const qint64 seconds = qMax(qint64(0), QDateTime::currentDateTime().secsTo(m_expiresAt));
        m_remainingTime = QStringLiteral("%1h : %2m : %3s")
            .arg(seconds / 3600).arg((seconds / 60) % 60).arg(seconds % 60);
        emit clockChanged();
    }
    QJsonArray m_records;
    QDate m_lastDate;
    QDateTime m_expiresAt;
    QString m_word;
    QString m_colour;
    QString m_currentTime;
    QString m_remainingTime;
    QTimer m_clock;
    QGyroscope m_gyroscope;
    QElapsedTimer m_motionTimer;
    qint64 m_lastMotionMs = -1;
    qreal m_gyroRotation = 0;
};

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    TicketController controller;
    QQmlApplicationEngine engine;

    // Create context property (for qml) 
    engine.rootContext()->setContextProperty(QStringLiteral("ticket"), &controller);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, [] { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
    engine.loadFromModule("BusPaszt", "Main");
    return app.exec();
}
#include "main.moc"
