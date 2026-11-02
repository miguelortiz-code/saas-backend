import { Router } from "express";
import { login, refreshToken, getMe } from "./auth.controller.js";
import { authenticate } from "../../middleware/auth.middleware.js";

const router = Router();

// Rutas públicas — no requieren token
router.post('/login', login);
router.post('/refresh-token', refreshToken);

// Rutas protegidas — requieren JWT válido
router.get('/me', authenticate, getMe);

export default router;