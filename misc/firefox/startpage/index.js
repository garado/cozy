var time = new Date();
time =  ("0" + time.getHours()).slice(-2)   + ":" + ("0" + time.getMinutes()).slice(-2)
document.getElementById("time").textContent = time
