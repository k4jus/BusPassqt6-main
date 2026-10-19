const gyroBox = document.getElementById("gyro-box");
const detailsTxt = document.getElementById("details-txt");
let gyro = null

// Make gyroBox responsive to gyroscopic movement

// Function for getting gyroscope permission
function getPermission() {
    navigator.permissions.query({name: "gyroscope"}).then(function(res) {
	if (res.state == "granted") {
	    console.log("Permission granted");
	}
	if (res.state == "denied") {
	    console.log("Permission denied");
	}
    });
}

//console.log(navigator);

// Check if gyroscope exists in permissions
if (!"gyroscope" in navigator) {
    console.error("No \"gyroscope\" available");
}

// Try catch clause for instantiating + setting gyro
try {
    gyro = new Gyroscope({referenceFrame: "device"});
    
    gyro.addEventListener("error", function(event) {
	if (event.error.name === "NotAllowedError") console.error(event.error.name);
	else if (event.error.name === "NotReadableError") console.error("Cant connect to gyro :(");
    });

    gyro.addEventListener("reading", function() {
	console.log("Listening...");
    });

    gyro.start();
} catch (err) {
    if (err.name === "SecurityError") {
	console.error("No permissions to use Gyro :((");
    } else throw err;
}

// Open settings pannel upon clicking on details-txt div
