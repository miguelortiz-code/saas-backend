import { Router } from "express";
import { login, refreshToken, getMe } from "./auth.controller.js";
import { authenticate } from "../../middleware/auth.middleware.js";
import {validate} from '../../middleware/validate.middleware.js';
import { loginRules, refreshTokenRules } from './auth.validator';

const router = Router();

// Rutas públicas — no requieren token
router.post('/login', loginRules, validate, login);
router.post('/refresh-token', refreshTokenRules, validate, refreshToken);

// Rutas protegidas — requieren JWT válido
router.get('/me', authenticate, getMe);

export default router;