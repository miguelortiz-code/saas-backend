import { Response, NextFunction } from "express";
import { AuthRequest } from "../../shared/types/index.js";
import { sendSuccess, sendCreated } from "../../shared/helpers/response.helper.js";
import { loginService, refreshTokenService, getMeService } from "./auth.service.js";

// POST - /api/v1/auth/login
export const login = async(
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> =>{
    try {
        const {email, password} = req.body;
        const result = await loginService(email, password);
        sendCreated(res, result, 'Inicio de sesión exitoso');
    } catch (error) {
        next(error);
    }
};

// POST - /api/v1/auth/refresh-token
export const refreshToken = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const {refreshToken} = req.body;
        const result =  await refreshTokenService(refreshToken);
        sendCreated(res, result, 'Token renovado');
    } catch (error) {
        next(error);
    }
};

// GET /api/v1/auth/me
export const getMe = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise <void> => {
    try {
        const result = await getMeService(req.user!.id, req.user!.schemaName);
        sendCreated(res, result);
    } catch (error) {
        next(error);
    }
};