import express, { Application } from 'express';
import dotenv from 'dotenv';
import solanaRoutes from './routes/solana';

dotenv.config();

const app: Application = express();
const port = process.env.PORT || 3000;

app.use('/solana', solanaRoutes);

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
