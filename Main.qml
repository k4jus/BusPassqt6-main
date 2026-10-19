import QtQuick
import QtQuick.Window
import QtQuick.Controls

Window {
    id: window
    visible: true
    title: "BusPaszt"
    color: frameBg

    readonly property color frameBg: "#071722"
    readonly property color mainBg: "#FAFAFA"
    readonly property color headerBg: "#123447" // darker navy to match target
    readonly property color detailsColor: "#2F735E"
    readonly property color codeBoxBg: "#D6D6D6"
    readonly property real unit: Math.max(1, window.width / 360)

    FontLoader {
        id: displayFont
        source: "assets/fonts/StageCoach-Regular.otf"
    }
    FontLoader {
        id: uiFont
        source: "assets/fonts/Google-Sans-Medium.ttf"
    }

    // Top header (status area)
    Rectangle {
        id: header
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: Math.max(56, window.height * 0.07)
        color: headerBg
        radius: 0
        Text {
            anchors.centerIn: parent
            text: "Your Ticket"
            color: mainBg
            font { family: uiFont.name; pointSize: 18 * unit; weight: Font.Bold }
        }

        // circular close button on the right
        Rectangle {
            id: closeBtnWrap
            width: header.height * 0.85
            height: header.height * 0.85
            radius: width / 2
            anchors { right: parent.right; rightMargin: 12 * unit; verticalCenter: parent.verticalCenter }
            color: "transparent"
            border.color: mainBg
            border.width: 3 * unit
            Image {
                anchors.centerIn: parent
                source: "assets/images/close.svg"
                width: parent.width * 0.55
                height: parent.height * 0.55
                fillMode: Image.PreserveAspectFit
            }
        }
    }

    // The card container (white inner panel) with a blue border and rounded corners
    Rectangle {
        id: mainPanel
        anchors { top: header.bottom; topMargin: 12 * unit;
                  left: parent.left; leftMargin: 12 * unit;
                  right: parent.right; rightMargin: 12 * unit;
                  bottom: parent.bottom; bottomMargin: 20 * unit }
        color: mainBg
        radius: 14 * unit
        border.color: headerBg
        border.width: 8 * unit
        clip: true

        Column {
            anchors { left: parent.left; right: parent.right; top: parent.top }
            anchors.margins: 18 * unit
            spacing: 18 * unit
            width: parent.width - 36 * unit

            // Top pill (price/description) anchored inside the card
            Rectangle {
                id: pricePill
                width: parent.width * 0.95
                height: Math.max(54 * unit, parent.height * 0.07)
                radius: height / 2
                color: headerBg
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: -26 * unit
                Row {
                    anchors.fill: parent
                    anchors.margins: 18 * unit
                    spacing: 8 * unit
                    Text {
                        text: "1 Adult"
                        color: mainBg
                        font { family: uiFont.name; pointSize: 18 * unit; weight: Font.DemiBold }
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Item { width: 1; Layout.fillWidth: true }
                    Text {
                        text: "£6.00"
                        color: mainBg
                        font { family: uiFont.name; pointSize: 18 * unit; weight: Font.DemiBold }
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            Item { height: Math.max(20 * unit, 24) }

            // QR code
            Image {
                id: qr
                width: parent.width * 0.6
                height: width
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                source: "assets/images/qr-code.png"
            }

            // Title
            Text {
                id: ticketTitle
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Bay DayRider"
                font { family: uiFont.name; pointSize: 34 * unit ; weight: Font.Bold; letterSpacing: 1 }
                color: "#0B2327"
            }

            // Valid from
            Text {
                id: ticketStartDate
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Valid from: 00:00, 28 May 2026"
                font { family: uiFont.name; pointSize: 13 * unit }
                color: "#000000"
            }

            // Decorative rotating banner (gyroBox) - centered and with rounded corners
            Rectangle {
                id: gyroBox
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.95
                height: Math.max(80 * unit, parent.height * 0.12)
                color: Qt.darker(ticket.colour, 1.1)
                radius: 8 * unit
                clip: true
                transform: Rotation {
                    origin.x: gyroBox.width / 2
                    origin.y: gyroBox.height / 2
                    angle: Math.max(-12, Math.min(12, ticket.gyroRotation))
                }

                Canvas {
                    id: bubbles
                    anchors.fill: parent
                    property var particles: []
                    Component.onCompleted: {
                        for (let i = 0; i < 10; ++i) {
                            const size = 10 + Math.random() * 70
                            particles.push({ x: Math.random() * width, y: Math.random() * height,
                                             size: size, speed: 1 / (size * 2),
                                             opacity: 0.08 + Math.random() * 0.6,
                                             radius: 20 / (size * 7), phase: 0 })
                        }
                    }
                    onPaint: {
                        const ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        ctx.fillStyle = "rgba(255,255,255,0.12)"
                        ctx.fillRect(0, height * 0.25, width, height * 0.5)
                        for (const b of particles) {
                            b.x -= Math.sin(b.phase) * b.radius
                            b.y += Math.cos(b.phase) * b.radius
                            b.phase -= b.speed
                            if (b.x > width + b.size) b.x = -b.size
                            if (b.x < -b.size) b.x = width + b.size
                            if (b.y > height + b.size) b.y = -b.size
                            if (b.y < -b.size) b.y = height + b.size
                            ctx.beginPath()
                            ctx.arc(b.x, b.y, b.size / 2, 0, Math.PI * 2)
                            ctx.fillStyle = "rgba(255,255,255," + b.opacity + ")"
                            ctx.fill()
                        }
                    }
                    Timer { interval: 16; running: true; repeat: true; onTriggered: bubbles.requestPaint() }
                }

                Text {
                    id: wordLabel
                    anchors.centerIn: parent
                    text: ticket.word
                    color: "#000000"
                    font { family: displayFont.name; pointSize: 48 * unit }
                    opacity: 1
                }
            }

            // Expiry row: label left, time right
            Row {
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8 * unit
                Text { text: "Ticket expires in"; font.pointSize: 13 * unit; color: "#000" }
                Item { Layout.fillWidth: true }
                Text { text: ticket.remainingTime; font.pointSize: 13 * unit; color: "#000" }
            }

            // Code / PIN pill
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.85
                height: Math.max(46 * unit, 40)
                radius: height / 2
                color: codeBoxBg
                Text {
                    anchors.centerIn: parent
                    text: "3443-20260528081346769-YBeJV"
                    font { family: uiFont.name; pointSize: 13 * unit }
                    color: "#222222"
                }
            }

            // More details
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "More details >"
                color: detailsColor
                font { family: uiFont.name; pointSize: 16 * unit }
                topPadding: 10 * unit
            }

            Item { height: 24 * unit }
        }
    }
}
