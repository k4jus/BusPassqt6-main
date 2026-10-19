const ticketExpire = document.getElementById("ticket-expire").children[1];
const gyroBox = document.getElementById("gyro-box");
const gyroCanvas = document.getElementById("gyro-canvas");
const gyroText = document.getElementById("gyro-text");
const gyroTime = document.getElementById("gyro-time");

const MAX_SIZE = 70;
const MIN_SIZE = 10;
const MAX_SPEED = 0.01;
const MIN_SPEED = 0.001;
const MAX_OPACITY = 0.8;
const MIN_OPACITY = 0.1;
const MAX_PATHRADIUS = 0.2;
const MIN_PATHRADIUS = 0.01;

const N_BUBBLES = 10;

const COLOURMAP = {
    "Orange": "#F9A03C",
    "Blue": "#009BDE",
    "Green": "#44CF8C",
    "Pink": "#EA427D",
    "Grey": "#B3BAC0",
};

// united requestAnimationFrame function
window.requestAnimFrame = (function(){
    return  window.requestAnimationFramer  ||
	window.webkitRequestAnimationFrame ||
	window.mozRequestAnimationFrame    ||
	window.oRequestAnimationFrame      ||
	window.msRequestAnimationFrame     ||
	function( callback ){
	    window.setTimeout(callback, 1000 / 60);
	};
})(); 
// Gyro box animation
let bubbles = [];

function addBubbles() {
    let size = Math.floor(MIN_SIZE + (Math.random() * MAX_SIZE));
    let x = Math.floor(size + (Math.random(101) * (gyroCanvas.width-size)));
    let y = Math.floor(size + (Math.random(101) * (gyroCanvas.height-size)));
    // let speed = MIN_SPEED + (Math.random() * MAX_SPEED);
    let speed = MAX_SPEED * 100 / (size * 2);
    let opacity = MIN_OPACITY + (Math.random() * MAX_OPACITY);
    // let pathRadius = MIN_PATHRADIUS + (Math.random() * MAX_PATHRADIUS);
    let pathRadius = MAX_PATHRADIUS * 100 / (size * 7);
    let direction = Math.random() < 0.5 ? -1 : 1;

    bubbles.push({
	x: x,
	y: y,
	size: size,
	speed: speed,
	opacity: opacity,
	direction: direction,
	deg: 0,
	pathRadius: pathRadius
    });
}

function bubbleAnimate(bubble) {
    // bubble.x += bubble.speed * bubble.direction;
    // bubble.y += bubble.speed * bubble.direction;
    bubble.x -= Math.sin(bubble.deg) * bubble.pathRadius;
    bubble.y += Math.cos(bubble.deg) * bubble.pathRadius;
    bubble.deg -= bubble.speed;
}

function updateBubbles() {
    for (b of bubbles) {
	let boundX = gyroCanvas.width + b.size;
	let boundY = gyroCanvas.height + b.size;
	if (b.y > boundY) b.y = -b.size;
	if (b.y < -b.size) b.y = boundY;
	if (b.x > boundX) b.x = -b.size;
	if (b.x < -b.size) b.x = boundX;

	bubbleAnimate(b);
    }
}

function drawBubbles(c) {
    for (let b of bubbles) {
	c.beginPath();
	c.arc(b.x, b.y, b.size/2, 0, Math.PI * 2);
	c.closePath();
	c.fillStyle = `rgba(255, 255, 255, ${b.opacity}`;
	c.fill();
    }
}

function animLoop() {
    window.requestAnimFrame(animLoop);
    
    updateBubbles();
    // updateText();

    let c = gyroCanvas.getContext("2d");
    c.clearRect(0, 0, gyroCanvas.width, gyroCanvas.height);
    drawBubbles(c);
    // drawText(c);
}

// Procedure to set gyroTime
function renderCurrentTime() {
    const date = new Date();
    gyroTime.innerText = (date.getHours() > 9 ? "" : "0") + date.getHours() + ":" + (date.getMinutes() > 9 ? "" : "0") + date.getMinutes();
}

// Function to return ticketExpire hours + minutes + seconds
function renderExpireTime(date) {
    let now = new Date();
    const dt = (date - now)/1000;
    return [Math.floor(dt/3600%24),Math.floor(dt/60%60), Math.floor(dt%60)]; 
}

// New function: date now - 1 Jan (year now) / 24 (hours) * 60 (mins) * 60 (secs) * 1000 (milsec)
function getDayOfYear(date) {
    // const monthdays = [31,28,31,30,31,30,31,31,30,31,30,31];
    // let day = date.getDate();
    // for (let i = 0; i <= date.getMonth()-1; i++) {
    // 	day += monthdays[i];
    // }
    return Math.floor((date - new Date(date.getFullYear(),0,1)) / 86400000);
}

//
// Runtime starts here
//

// Add bubbles to list
for (let i = 0; i < N_BUBBLES; i++) {
    addBubbles();
}
// Start the animation
window.requestAnimFrame(animLoop);

// Set the timeout for gyroTime to update each minute
let DATE = new Date();
renderCurrentTime();
setInterval(function() {
    renderCurrentTime();
}, 60000);

// Update gyroText + gyroBox colour on startup
const DAY_RECORD = DATA[getDayOfYear(DATE)];
gyroText.innerText = DAY_RECORD.word;
gyroBox.style.backgroundColor = COLOURMAP[DAY_RECORD.colour];

// Update ticket-expire text
const now = new Date();
setInterval(function () {
    const rend = renderExpireTime((now.getTime() + 86400000));
    ticketExpire.innerText = rend[0]+"h : "+rend[1]+"m : "+rend[2]+"s";
}, 1000);
