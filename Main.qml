import QtQuick
import QtQuick.Window
import QtQuick.Controls

Window {
    id: window
    visible: true
    title: "BusPaszt"
    color: frameBg

    readonly property color frameBg: "#0A1C2B"
    readonly property color mainBg: "#FAFAFA"
    readonly property color headerBg: "#0F2E55"
    readonly property color detailsColor: "#3B8169"
    readonly property color codeBoxBg: "#D0D0D0"
    readonly property real unit: 1;

    FontLoader {
        id: displayFont
	source: "assets/fonts/StageCoach-Regular.otf"
    }
    FontLoader {
        id: uiFont
	source: "assets/fonts/Google-Sans-Medium.ttf"
    }

    Rectangle {
        id: header
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: Math.max(52, window.height * 0.065)
        color: headerBg
        Text {
            anchors.centerIn: parent
            text: "Your Ticket"
            color: mainBg
            font { family: uiFont.name; pointSize: 18; weight: Font.Bold }
        }
        Image {
	    width: parent.height - 6
	    height: parent.height - 6
            anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
	    source: "assets/images/close.svg"
        }
    }

    Rectangle {
        id: mainPanel
        anchors { top: header.bottom; topMargin: 2 * window.height / 100;
                  left: parent.left; leftMargin: 1.5 * window.height / 100;
                  right: parent.right; rightMargin: 1.5 * window.height / 100;
                  bottom: parent.bottom; bottomMargin: 2 * window.height / 100 }
        color: mainBg
        Column {
            anchors { top: parent.top; topMargin: 88; horizontalCenter: parent.horizontalCenter }
            width: parent.width
            spacing: 30
            Image {
                width: parent.width
                height: 180
		fillMode: Image.PreserveAspectFit
		source: "assets/images/qr-code.png"
            }
            Text {
	        id: ticketTitle
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Bay DayRider"
                font { family: uiFont.name; pointSize: 27 ; weight: Font.Bold; letterSpacing: 1 }
                color: "#000000"
            }
            Text {
	        id: ticketStartDate
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Valid from: 00:00, 28 May 2026"
                font { family: uiFont.name; pointSize: 13  }
                color: "#000000"
            }
            Item { width: 1; height: 60 * unit }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8 * unit
                Text { text: "Ticket expires in"; font.pointSize: 13  }
                Item { width: Math.max(20, window.width * 0.12); height: 1 }
                Text { text: ticket.remainingTime; font.pointSize: 13  }
            }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.min(parent.width - 20 * unit, 295 * unit)
                height: 32 * unit
                radius: 8 * unit
                color: codeBoxBg
                Text {
                    anchors.centerIn: parent
                    text: "3443-20260528081346769-YBeJV"
                    font { family: uiFont.name; pointSize: 13  }
                    color: "#000000"
                }
            }
	    Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "More details >"
                    color: detailsColor
                    font { family: uiFont.name; pointSize: 16  }
                    topPadding: 10 * unit
	    }
        }
    }

    Rectangle {
        id: priceBox
        x: 0
        y: window.height * 0.10
        width: window.width * 0.82
        height: 55 * unit
        color: frameBg
        radius: 14 * unit
        // Square off the left edge as in border-radius: 0 2vh 2vh 0.
        Rectangle { width: parent.radius; height: parent.height; color: parent.color }
        Text {
            anchors { left: parent.left; leftMargin: window.width * 0.10; verticalCenter: parent.verticalCenter }
            text: "1 Adult"
            color: mainBg
            font { family: uiFont.name; pointSize: 19 ; bold: true }
        }
        Text {
            anchors { right: parent.right; rightMargin: 18 * unit; verticalCenter: parent.verticalCenter }
            text: "£6.00"
            color: mainBg
            font { family: uiFont.name; pointSize: 19 ; bold: true }
        }
    }

    Rectangle {
        id: gyroBox
        x: window.width * 0.03
        y: window.height * 0.56
        width: window.width * 0.94
        height: window.height * 0.08
        color: ticket.colour
        clip: true
        transform: Rotation {
            origin.x: gyroBox.width / 2
            origin.y: gyroBox.height / 2
            angle: Math.max(-15, Math.min(15, ticket.gyroRotation))
        }
        Canvas {
            id: bubbles
            anchors { centerIn: parent; horizontalCenterOffset: 0 }
            width: parent.width * 0.70
            height: parent.height
            property var particles: []
            Component.onCompleted: {
                for (let i = 0; i < 10; ++i) {
                    const size = 10 + Math.random() * 70
                    particles.push({ x: Math.random() * width, y: Math.random() * height,
                                     size: size, speed: 1 / (size * 2),
                                     opacity: 0.1 + Math.random() * 0.8,
                                     radius: 20 / (size * 7), phase: 0 })
                }
            }
            onPaint: {
                const ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
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
            font { family: displayFont.name; pointSize: 42 }
            opacity: 1
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { from: 1; to: 1; duration: 750 }
                NumberAnimation { from: 1; to: 0; duration: 1000 }
                NumberAnimation { from: 0; to: 0; duration: 750 }
                NumberAnimation { from: 0; to: 1; duration: 1000 }
            }
        }
        Text {
            anchors.centerIn: parent
            text: ticket.currentTime
            color: "#000000"
            font { family: displayFont.name; pointSize: 42 }
            opacity: 0
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { from: 0; to: 0; duration: 750 }
                NumberAnimation { from: 0; to: 1; duration: 1000 }
                NumberAnimation { from: 1; to: 1; duration: 750 }
                NumberAnimation { from: 1; to: 0; duration: 1000 }
            }
        }
    }
}
