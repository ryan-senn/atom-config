'use babel';

import child_process from 'child_process';

import { BufferedProcess } from 'atom';

export default class WorkerProcess {

    constructor(supervisor, elm) {
        this.supervisor = supervisor;
        this.elm = elm;

        this.isProcessing = false;

        this.nodeProcess = child_process.fork(`${__dirname}/worker.js`, [], { silent: true });
        this.nodeProcess.on("message", message => this.handleMessage(message));
    }

    /* ==============================
        PUBLIC
       ============================== */

    processFile(name) {
        this.isProcessing = true;
        this.nodeProcess.send({
            name: "processFile",
            filePath: name
        });
    }

    terminate() {
        this.nodeProcess.send({ name: "exit" });
    }

   /* ==============================
       PRIVATE
      ============================== */

    handleMessage(message) {
        const name = message.name;

        if (name === "finishedProcessing") {
            this.isProcessing = false;
            this.elm.ports.processReport.send(message.data);
            this.supervisor.onWorkerReady(this);
        }
    }

}
