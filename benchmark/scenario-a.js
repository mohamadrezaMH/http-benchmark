
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
    vus: 50, //Virtual Users karbar majazi , ehtemalan moadele workere
    duration: '30s',
};

export default function () {
    const response = http.get('http://localhost:8000/api/test');

    check(response, {
        'status is 200': (r) => r.status === 200,
        'response has success status': (r) => {
            return r.json('status') === 'success';
        },
    });

    sleep(0.1);
}
