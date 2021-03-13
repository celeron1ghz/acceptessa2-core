module.exports.main = async (event) => {
  console.log(JSON.stringify(event));
  const result = [];

  for (const r of event.Records) {
    const received = JSON.parse(r.Sns.Message);
    const mail = received.mail;
    delete mail.headers;

    console.log(JSON.stringify(received));

    const row = {
      mail,
    };

    result.push({ Data: JSON.stringify(row) + "\n" });
  }

  console.log(JSON.stringify(result));
  // await firehose.putRecordBatch({
  //   DeliveryStreamName: process.env.FIREHOSE_DELIVERY_STREAM_NAME,
  //   Records: result
  // }).promise();

  return "OK";
};