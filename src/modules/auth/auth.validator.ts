import {body} from 'express-validator';

// Reglas para POST /auth/login
export const loginRules = [
    body('email')
    .trim()
    .notEmpty().withMessage('El correo electrónico es obligatorio').bail()
    .isEmail().withMessage('El correo electrónico no es válido'),
    body('password')
    .notEmpty().withMessage('La contraseña es obligatoria').bail()
    .isString().withMessage('La contraseña debe ser texto'),
];

// Reglas para POST /auth/refresh-token
export const refreshTokenRules = [
    body('refreshToken')
    .trim()
    .notEmpty().withMessage('El refresh del token es obligatorio').bail()
    .isString().withMessage('El refresh del token debe ser texto'),
];