import {Request, Response, NextFunction} from 'express';
import {validationResult} from 'express-validator';
import { sendBadRequest } from '../shared/helpers/response.helper.js';

// Revisa las reglas de express-validator: si alguna falló responde 400, si no, continúa
export const validate = (req: Request, res: Response, next: NextFunction): void =>{
    const result = validationResult(req);

    if(result.isEmpty()){
        next();
        return;
    }

    const errors = result.array().map((e) => String(e.msg));
    sendBadRequest(res, 'Datos inválidos', errors);
};