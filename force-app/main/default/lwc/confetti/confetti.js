import CONFETTI from '@salesforce/resourceUrl/Confetti';
import { loadScript } from 'lightning/platformResourceLoader';

function loadConfetti(object) {
    loadScript(object,CONFETTI);
}

function basicCannon() {
    confetti({
        particleCount: 400,
        startVelocity: 60,
        spread: 150,
        origin: {
            y: 0.9
        }
    });
    console.log('after launching confetti')
}

function fireworks (){
    var end = Date.now() + (15 * 100);
    
    var interval = setInterval(function() {
        if (Date.now() > end) {
            return clearInterval(interval);
        }
        
        confetti({
            particleCount : 450,
            startVelocity: 30,
            spread: 360,
            ticks: 60,
            origin: {
                x: Math.random(),
                // since they fall down, start a bit higher than random
                y: Math.random() - 0.2
            }
        });
    }, 200);
}

function confettiShower (){
    var end = Date.now() + (15 * 100);
    
    (function frame() {
        confetti({
            particleCount: 10,
            startVelocity: 0,
            ticks: 300,
            origin: {
                x: Math.random(),
                // since they fall down, start a bit higher than random
                y: 0
            }
        });
        
        if (Date.now() < end) {
            requestAnimationFrame(frame);
        }
    }());
}

function winnerCelebration() {
    var end = Date.now() + (15 * 100);
    
    (function frame() {
        confetti({
            particleCount: 10,
            angle: 60,
            spread: 25,
            origin: {
                x: 0,
                y : 0.65
            }
        });
        confetti({
            particleCount: 10,
            angle: 120,
            spread: 25,
            origin: {
                x: 1,
                y : 0.65
            }
        });
        
        if (Date.now() < end) {
            requestAnimationFrame(frame);
        }
    }());
}

function busrtMode() {
    
    var end = Date.now() + (15 * 75);
    
    // go Buckeyes!
    var colors = ['#610B0B','#FFFF00','#FF00BF','#0040FF','#585858','#00FFBF','#FE642E','#FFBF00','#0101DF','#FF8000','#00FF00','#FF0040','#A901DB','#0B0B3B','#FF0000'];
    
    (function frame() {
        confetti({
            particleCount: 7,
            startVelocity: 25,
            angle: 335,
            spread: 10,
            origin: {
                x: 0,
                y: 0,
            },
            colors: colors
        }); 
        confetti({
            particleCount: 7,
            startVelocity: 25,
            angle: 205,
            spread: 10,
            origin: {
                x: 1,
                y: 0,
            },
            colors: colors
        });
        
        confetti({
            particleCount: 7,
            startVelocity: 35,
            angle: 140,
            spread: 30,
            origin: {
                x: 1,
                y: 1,
            },
            colors: colors
        });
        
        confetti({
            particleCount: 7,
            startVelocity: 35,
            angle: 40,
            spread: 30,
            origin: {
                x: 0,
                y: 1,
            },
            colors: colors
        });
        
        if (Date.now() < end) {
            requestAnimationFrame(frame);
        }
    }());
}


export {loadConfetti, basicCannon, fireworks, confettiShower, winnerCelebration, busrtMode};