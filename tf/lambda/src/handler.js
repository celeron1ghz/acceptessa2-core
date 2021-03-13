'use strict';

const aws = require('aws-sdk');
const firehose = new aws.Firehose();

function flatten(data) {
  if (!data) {
    return null;
  }

  const ret = {};

  try {
    for (const [key, val] of Object.entries(data)) {
      ret[key] = Object.entries(val)[0][1];
    }

  } catch (error) {
    console.log("error on extracting data: ", error);
  }

  return ret;
}

module.exports.main = async (event) => {
  const result = [];

  for (const r of event.Records) {
    //console.log(JSON.stringify(r.dynamodb));
    const splitted = r['eventSourceARN'].split("/");
    const epoch = r.dynamodb.ApproximateCreationDateTime;

    const row = {
      table: splitted[1],
      action: r['eventName'],
      newImage: flatten(r.dynamodb.NewImage),
      oldImage: flatten(r.dynamodb.OldImage),
      userIdentity: r.userIdentity,
      timestampEpoch: epoch,
      timestampUtc: new Date(epoch * 1000).toISOString(),
    };

    result.push({ Data: JSON.stringify(row) + "\n" });
  }

  //console.log(JSON.stringify(result));
  await firehose.putRecordBatch({
    DeliveryStreamName: process.env.FIREHOSE_DELIVERY_STREAM_NAME,
    Records: result
  }).promise();

  return "OK";
};
