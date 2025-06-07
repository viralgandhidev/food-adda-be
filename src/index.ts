import 'reflect-metadata';
import {container} from './application/di/container';
import {TYPES} from './application/di/types';
import {App} from './app';

const app = container.get<App>(TYPES.App);
app.listen();
