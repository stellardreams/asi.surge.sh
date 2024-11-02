console.log("Hello, World!");

// Functionality for the navigation menu
document.addEventListener("DOMContentLoaded", function() {
    const navLinks = document.querySelectorAll("nav ul li a");
    navLinks.forEach(link => {
        link.addEventListener("click", function(event) {
            event.preventDefault();
            const target = event.target.getAttribute("href");
            window.location.href = target;
        });
    });
});

// Programmatically calculate the new top position by directly adding 30 mm to the existing position, you can do this:
function createSun() {
    const sun = document.getElementById('sun');
    sun.style.position = 'absolute';
    sun.style.top = '6.1in';
    sun.style.left = '0.5in';  // Position sun 0.5 inches from the left
    sun.style.right = 'auto';  // Ensure right side positioning is cleared
    sun.style.width = '1in';
    sun.style.height = '1in';
    sun.style.backgroundColor = 'yellow';
    sun.style.borderRadius = '50%';
    sun.style.boxShadow = '0 0 20px yellow';
}

// Ensure the DOM has loaded before calling the function
window.onload = createSun;


function makeSunWobble() {
    const sun = document.getElementById('sun');
    let angle = 0;
    setInterval(() => {
        angle += 0.05; // Slow down the increment for a gentler movement
        sun.style.transform = `translateY(${Math.sin(angle) * 2}px)`; // Use a smaller multiplier for subtle movement
    }, 50); // Slightly slower interval for smoother wobbling
}

makeSunWobble();

/*
const projects = {
    data: [
        {id: 1, text: "Project 01", start_date: "01-01-2025", duration: 45},
        {id: 2, text: "Project 02", start_date: "15-02-2025", duration: 45},
        {id: 3, text: "Project 03", start_date: "01-04-2025", duration: 45},
        {id: 4, text: "Project 04", start_date: "15-05-2025", duration: 45},
        {id: 5, text: "Project 05", start_date: "01-07-2025", duration: 45},
        {id: 6, text: "Project 06", start_date: "15-08-2025", duration: 45}
    ]
};

gantt.init("gantt_here");
gantt.parse(projects);

function promptPassword() {
    const password = prompt("Enter password to modify Gantt chart:");
    if (password === "wintercabinjsh") {
        alert("Access granted. You can now modify the Gantt chart.");
    } else {
        alert("Access denied. Incorrect password.");
    }
}

document.getElementById("gantt_here").addEventListener("dblclick", promptPassword);

function createBrickWall() {
    const wall = document.getElementById('brick-wall');
    wall.style.position = 'absolute';
    wall.style.top = '3.5in';
    wall.style.right = '0.5in';
    wall.style.width = '2in';
    wall.style.height = '1.5in';
    wall.style.backgroundColor = '#8B4513';
    wall.style.border = '1px solid #5A2D0C';
    wall.style.zIndex = '-1'; // Ensure the wall is behind the sun
}
*/


/*
createBrickWall();

function create3DSolarSystem() {
    const canvas = document.getElementById('solarSystemCanvas');
    const ctx = canvas.getContext('2d');

    const sun = {
        x: canvas.width / 2,
        y: canvas.height / 2,
        radius: 50,
        color: 'yellow'
    };

    const planets = [
        { radius: 10, distance: 100, speed: 0.02, angle: 0, color: 'gray' },
        { radius: 15, distance: 150, speed: 0.015, angle: 0, color: 'orange' },
        { radius: 20, distance: 200, speed: 0.01, angle: 0, color: 'blue' },
        { radius: 25, distance: 250, speed: 0.005, angle: 0, color: 'red' }
    ];

    function drawSun() {
        ctx.beginPath();
        ctx.arc(sun.x, sun.y, sun.radius, 0, Math.PI * 2);
        ctx.fillStyle = sun.color;
        ctx.fill();
        ctx.closePath();
    }

    function drawPlanets() {
        planets.forEach(planet => {
            planet.angle += planet.speed;
            const x = sun.x + planet.distance * Math.cos(planet.angle);
            const y = sun.y + planet.distance * Math.sin(planet.angle);

            ctx.beginPath();
            ctx.arc(x, y, planet.radius, 0, Math.PI * 2);
            ctx.fillStyle = planet.color;
            ctx.fill();
            ctx.closePath();
        });
    }

    function animate() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        drawSun();
        drawPlanets();
        requestAnimationFrame(animate);
    }

    animate();
}

create3DSolarSystem();

function moveSolarSystemUp() {
    const canvas = document.getElementById('solarSystemCanvas');
    canvas.style.top = 'calc(100px - 3.5in)';
}

moveSolarSystemUp();

document.querySelector('nav select').addEventListener('change', function() {
    window.location.href = this.value;
});

function addFloatingLotus() {
    const lotus = document.createElement('div');
    lotus.id = 'floating-lotus';
    lotus.style.position = 'relative';
    lotus.style.width = '100%';
    lotus.style.height = '200px';
    lotus.style.background = 'url("https://example.com/lotus-flower.png") no-repeat center center';
    lotus.style.backgroundSize = 'contain';
    document.getElementById('contact-form').insertAdjacentElement('afterend', lotus);
}

addFloatingLotus();

function addPages() {
    for (let i = 1; i <= 10; i++) {
        const pageName = `new-page${i}.html`;
        const pageContent = `
            <!DOCTYPE html>
            <html>
            <head>
                <title>New Page ${i}</title>
            </head>
            <body>
                <h1>New Page ${i}</h1>
                <p>This is the content of new page ${i}.</p>
            </body>
            </html>
        `;
        const blob = new Blob([pageContent], { type: 'text/html' });
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = pageName;
        link.click();
    }
    updateNavigationMenu();
}

function deletePages() {
    for (let i = 1; i <= 10; i++) {
        const pageName = `new-page${i}.html`;
        const link = document.createElement('a');
        link.href = pageName;
        link.download = pageName;
        link.click();
    }
    updateNavigationMenu();
}

function updateNavigationMenu() {
    const nav = document.querySelector('nav select');
    for (let i = 1; i <= 10; i++) {
        const option = document.createElement('option');
        option.value = `new-page${i}.html`;
        option.textContent = `New Page ${i}`;
        nav.appendChild(option);
    }
}

document.getElementById('add-pages-btn').addEventListener('click', addPages);
document.getElementById('delete-pages-btn').addEventListener('click', deletePages);

*/


/*

// Function to stack bricks in animation to make it seem like the wall is being built
function stackBricks() {
    const wall = document.getElementById('brick-wall');
    wall.innerHTML = ''; // Clear any existing bricks

    const brickWidth = 20;
    const brickHeight = 10;
    const wallWidth = wall.clientWidth;
    const wallHeight = wall.clientHeight;
    const bricksPerRow = Math.floor(wallWidth / brickWidth);
    const rows = Math.floor(wallHeight / brickHeight);

    for (let row = 0; row < rows; row++) {
        for (let col = 0; col < bricksPerRow; col++) {
            const brick = document.createElement('div');
            brick.style.width = `${brickWidth}px`;
            brick.style.height = `${brickHeight}px`;
            brick.style.backgroundColor = '#B22222';
            brick.style.position = 'absolute';
            brick.style.left = `${col * brickWidth}px`;
            brick.style.top = `${row * brickHeight}px`;
            brick.style.transition = 'top 0.5s ease-in-out';
            wall.appendChild(brick);

            // Delay the stacking of each brick to create the animation effect
            setTimeout(() => {
                brick.style.top = `${row * brickHeight}px`;
            }, row * 100 + col * 50);
        }
    }
}

// Call the function to start the brick stacking animation when the page loads
document.addEventListener('DOMContentLoaded', stackBricks);

*/


// Highlighting the code for the sun element
// To embed the sun element in another website, you can copy the following code snippet and include it in the HTML file of the target website:


// script.js
function createSun() {
    const sun = document.getElementById('sun');
    sun.style.position = 'absolute';
    sun.style.top = '6.1in';
    sun.style.right = '0.5in';
    sun.style.width = '1in';
    sun.style.height = '1in';
    sun.style.backgroundColor = 'yellow';
    sun.style.borderRadius = '50%';
    sun.style.boxShadow = '0 0 20px yellow';
}

function makeSunWobble() {
    const sun = document.getElementById('sun');
    let angle = 0;
    setInterval(() => {
        angle += 0.1;
        sun.style.transform = `translateY(${Math.sin(angle) * 5}px)`;
    }, 100);
}

window.onload = function() {
    createSun();
    makeSunWobble();
};

