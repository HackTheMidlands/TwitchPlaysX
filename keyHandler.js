let exec = require("child_process").exec,
  config = require("./config.js"),
  lastTime = {},
  windowID = "unfilled",
  throttledCommands = config.throttledCommands,
  regexThrottle = new RegExp("^(" + throttledCommands.join("|") + ")$", "i"),
  regexFilter = new RegExp(
    "^(" + config.filteredCommands.join("|") + ")$",
    "i"
  );

let isWindows = process.platform === "win32";
const commandRegex = new RegExp(
  "^(" + config.commands.join("|") + ")( [0-5])?$",
  "i"
);

(function setWindowID() {
  if (!isWindows & (windowID === "unfilled")) {
    exec("xdotool search --onlyvisible --name " + config.programName, function (
      error,
      stdout
    ) {
      windowID = stdout.trim();
      // console.log(key, windowID);
    });
  }
})();

for (let i = 0; i < throttledCommands.length; i++) {
  lastTime[throttledCommands[i]] = new Date().getTime();
}

let defaultKeyMap = config.keymap || {
  up: "w",
  left: "a",
  down: "s",
  right: "d",
  a: "l",
  b: "k",
  x: "x",
  y: "y",
  start: "s",
  select: "e",
};

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function sendKey(command) {
  //if doesn't match the filtered words
  if (!command.match(regexFilter)) {
    console.log(command);
    let allowKey = true;
    let elems = commandRegex.exec(command);
    console.log(elems);
    let key = defaultKeyMap[elems[1]] || command;
    let count = parseInt(elems[2]) || 1;
    console.log(key, count);
    //throttle certain commands (not individually though)
    if (key.match(regexThrottle)) {
      let newTime = new Date().getTime();
      if (newTime - lastTime[key] < config.timeToWait) {
        allowKey = false;
      } else {
        lastTime = newTime;
      }
    }
    if (allowKey) {
      if (isWindows) {
        exec("python key.py" + "  " + config.programName + " " + key);
      } else {
        for (var i = 0; i < count; i++) {
          console.log(i, key, count);
          //Send to preset window under non-windows systems
          exec(
            "xdotool key --window " +
              windowID +
              " --delay " +
              config.delay +
              " " +
              key
          );
          await sleep(config.delay);
        }
      }
    }
  }
}

exports.sendKey = sendKey;
