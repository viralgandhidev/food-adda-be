import jwt, { JwtPayload } from "jsonwebtoken";
import { UnauthorizedError } from "./appErrors";

class JwtUtil {
    public signToken(data: Record<string, any>): string {
        console.log('jwtSect', process.env.JWT_SECRET);
        
        const accessToken = jwt.sign(data, process.env.JWT_SECRET, {expiresIn: '24h'});
        return accessToken;
    }

    public verifyToken(accessToken: string): string | JwtPayload {
        try {
            console.log('jwtSect', process.env.JWT_SECRET);
            const decodedData = jwt.verify(accessToken, process.env.JWT_SECRET)
            return decodedData;
        } catch(error) {
            throw new UnauthorizedError();
        }
    }
}

export default JwtUtil;