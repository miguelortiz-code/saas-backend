import { Response, NextFunction } from "express";
import { AuthRequest } from "../shared/types/index.js";
import { sendForbidden } from "../shared/helpers/response.helper.js";

// Verifica que el usuario pertenezca a un tenant válido
// Se usa en todas las rutas que operan dentro de una empresa
export const resolveTenant = (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): void => {
    const schema = req.user?. schemaName;

    // El schema siempre debe empezar con "tenant_"
    if(!schema || !schema.startsWith('tenant_')){
        sendForbidden(res, 'Tenant no identificado');
        return;
    }

    req.schemaName = schema;
    next();
};