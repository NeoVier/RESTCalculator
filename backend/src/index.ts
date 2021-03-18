import cors from "cors";
import express from "express";

const main = async () => {
  const app = express();

  app.use(express.json());
  app.use(cors());

  app.post("/sum", (req, res) => {
    const { firstOperand, secondOperand } = req.body;

    res.send({ operationResult: firstOperand + secondOperand });
  });

  app.post("/subtract", (req, res) => {
    const { firstOperand, secondOperand } = req.body;

    res.send({ operationResult: firstOperand - secondOperand });
  });
  app.post("/multiply", (req, res) => {
    const { firstOperand, secondOperand } = req.body;

    res.send({ operationResult: firstOperand * secondOperand });
  });
  app.post("/divide", (req, res) => {
    const { firstOperand, secondOperand } = req.body;

    res.send({ operationResult: firstOperand / secondOperand });
  });

  app.listen(4000, () => {
    console.log("server started on port 4000");
  });
};

main();
