import cors from "cors";
import express from "express";

const app = express();

app.use(cors());
app.use(express.json());

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
