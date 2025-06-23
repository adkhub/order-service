const serviceUrl = 'https://order-service-dev-894787498678.us-central1.run.app';
const createUrl = `${serviceUrl}/orders/create`;
const orderDescription = 'Table';

async function sendCreateAndConfirmRequests() {
  for (let i = 0; i < 20; i++) {
    try {
      const createResponse = await fetch(createUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'text/plain' },
        body: orderDescription
      });
      const createData = await createResponse.json();
      console.log(`Order ${i + 1} created:`, createData);
      const orderId = createData.id;
      if (!orderId) {
        console.error(`Order ${i + 1} creation failed: No ID returned.`);
        continue;
      }
      const confirmUrl = `${serviceUrl}/orders/${orderId}/confirm`;
      const confirmResponse = await fetch(confirmUrl, {
        method: 'POST'
      });
      const confirmData = await confirmResponse.text();
      console.log(`Order ${i + 1} confirmed:`, confirmData);
    } catch (error) {
      console.error(`Order ${i + 1} failed:`, error);
    }
  }
}

sendCreateAndConfirmRequests();
