// import http from 'k6/http';
// import { check, sleep } from 'k6';

// export const options = {
//     vus: 50, //Virtual Users karbar majazi , ehtemalan moadele workere
//     duration: '30s',
// };

// export default function () {
//     const response = http.get('http://localhost:8000/api/test');

//     check(response, {
//         'status is 200': (r) => r.status === 200,
//         'response has success status': (r) => {
//             return r.json('status') === 'success';
//         },
//     });

//     sleep(0.1);
// }



import http from 'k6/http';
import { check, sleep } from 'k6';

// Read test configuration from environment variables
const VUS = Number(__ENV.VUS || 10);
const DURATION = __ENV.DURATION || '60s';
const SLEEP_TIME = Number(__ENV.SLEEP || 0.1);
const BASE_URL = __ENV.BASE_URL || 'http://localhost:8000';

export const options = {
    vus: VUS,
    duration: DURATION,
};

export default function () {
    const response = http.get(`${BASE_URL}/api/test`);

    // check(response, {
    //     'status is 200': (r) => r.status === 200,
    //     'response has success status': (r) => {
    //         return r.json('status') === 'success';
    //     },
    // });
    check(response, {
    'status is 200': (r) => r.status === 200,
    'response has success status': (r) => {
        return r.status === 200 &&
            r.body !== null &&
            r.json('status') === 'success';
    },
});

    sleep(SLEEP_TIME);
}
