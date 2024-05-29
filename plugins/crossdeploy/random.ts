const axios = require('axios');


async function postToken(ciphertext: string): Promise<void> {
    const data = {
        ciphertext: ciphertext
    };
  
    try {
        const response = await axios.post('https://hyperlane-ccip.vercel.app/token', data, {
            headers: {
                'Content-Type': 'application/json'
            }
        });
        console.log(response.data);
    } catch (error) {
        console.error(error);
    }
}


postToken("hello_world!");