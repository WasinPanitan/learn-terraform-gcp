require('dotenv').config();
const axios = require('axios').default;

exports.healthCheck = (req, res) => {
  console.log('PROCESS_ENV.url ', process.env.url);
  console.log('Invoking now calling dog.ceo');
  axios.get(process.env.url)
  .then((response) => {
    console.log('RESPONSE ', response?.data?.status);
    console.log('Calling Slack Webhook');
    res.status(200).send(response?.data?.status);
  })
  .catch((error) => {
    console.log('ERROR > ', error.message);
    res.status(500);
  })
}
