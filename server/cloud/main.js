//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> AdyLix Routing for Push APIs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
Parse.Cloud.afterSave("ItemLike", function(request) {
  // trigger to fire after user likes an item
  console.log("Push in progress");
  var itemId = request.object.get('itemId');
  var userId = request.object.get('userTo').id;
  var styleId = request.object.get('styleId').id;

  var userQuery = new Parse.Query(Parse.User);
  userQuery.equalTo("objectId", userId);
  
  var pushQuery = new Parse.Query(Parse.Installation);
  pushQuery.equalTo('deviceType', 'ios');
  pushQuery.matchesQuery('user', userQuery);


  if(itemId) { // individual item like
      var itemObj = Parse.Object.extend("ItemDetail");
      var itemQuery  = new Parse.Query(itemObj);

      itemQuery.get(itemId, {
      success: function(object) {
         var name = object.get("name");
         Parse.Push.send({
          where: pushQuery, // Set our Installation query
          data: {
            alert: "Received New Like for Item "  + name,
            badge: "Increment"
          }
       }, {
        success: function() {
          // Push was successful
          console.log('Like item success');
        },
        error: function(error) {
          throw "Got an error " + error.code + " : " + error.message;
        }
      });

      },

      error: function(object, error) {
         throw "Got an error " + error.code + " : " + error.message;
      }
    });
 } else { // whole style like
      var styleObj = Parse.Object.extend("StyleMaster");
      var styleQuery  = new Parse.Query(styleObj);

      styleQuery.get(styleId, {
      success: function(object) {
         var name = object.get("name");
         Parse.Push.send({
          where: pushQuery, // Set our Installation query
          data: {
            alert: "Received New Like for Style " + name,
            badge: "Increment"
          }
       }, {
        success: function() {
          // Push was successful
          console.log('Like style success');
        },
        error: function(error) {
          throw "Got an error " + error.code + " : " + error.message;
        }
      });
    },
      error: function(object, error) {
         throw "Got an error " + error.code + " : " + error.message;
      }
    });
 }

});

//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> AdyLix Routing for Payment APIs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
var Stripe = require("stripe");
Stripe.initialize("sk_test_0hmo7YaWTsDPo1KouO8hRrEN");
var PaymentModule;
// #TODO: change to live secret key in production
// #TODO: define error codes
//stripe("pk_test_qEGQmR4XAdo9rIQDsU30dKBZ"); 
PaymentModule = Parse.Object.extend("PaymentModule", {
  // Instance methods
  pay: function (params, callback) {

  try
  {
  var customerId = params.sourceId;
  var val = parseFloat(params.value) * 100;
  var recipientId = params.destinationId;
  // transaction from source to our stripe account
	var charge = Stripe.Charges.create({
 	    amount: val, // amount in cents ????
  		currency: "usd",
  		customer: customerId,
  	  description: "AdyLix charge"
	},{
      success: function(httpResponse) {
        // our charge went thro
        // now pay recepient
        Stripe.Transfers.create({
              amount: val, // amount in cents
              currency: "usd",
              destination: recipientId,
              //bank_account: bank_account_id, //or // card: recipient.cardId
              statement_descriptor: "AdyLix Transfer"
            }, {
            success: function(httpResponse) {
             callback({success: true});
            },
            error: function(httpResponse) {
                 callback({success: false});
              }
             
            });
      },
      error: function(httpResponse) {
          callback({success: false});
        }
       
      });

} catch(e)
 {
    callback({success: false});
 }
}/*,
  // Instance properties go in an initialize method
  initialize: function (attrs, options) {
  }*/
}, {
  // Class methods
   validateCharge: function (obj) {
  	if(obj.sourceId == undefined 
  		|| obj.destinationId == undefined
  		|| obj.value == undefined)
    return false;

    return true;
  },

  validateCustomer:function (obj) {
    if(obj.sourceId == undefined 
    || obj.userEmail == undefined 
    || obj.userName == undefined)
      return false;

    return true;
  }
});

// define API for receive: register bank account
Parse.Cloud.define("registerSender", function(request, response) {
 var params = JSON.parse(request.body);
 if(!PaymentModule.validateCustomer(params)) {
    response.error("Invalid request params");
  }
  else {
    try
    {
      var customer = Stripe.Customers.create({
        card: request.params.sourceId,
        description: "Adylix customer",
        email: request.params.userEmail
      },{
      success: function(httpResponse) {
       // console.log(httpResponse);
        var result = {};
        result.success = true;
        result.tokenId = httpResponse.id;
        response.success(result);
      },
      error: function(httpResponse) {
          response.error(JSON.stringify({error:1, msg:"Error: "+httpResponse.message+"\n"+
                 "Params:\n"+
                 request.params.token+","+
                 request.params.plan+","+
                 request.params.quantity+
                 "\n"}));
        }
       
      });
   } catch(e)
   {
      response.error({success:false, msg:"something went wrong"});
   }
  }
});


// define API for pay: source paying destination 
// param: stripe token
Parse.Cloud.define("transfer", function(request, response) {
  var params = JSON.parse(request.body);
  if(!PaymentModule.validateCharge(params)) {
    response.error("Invalid request params");
  }
  else
   {
    var paymentModule = new PaymentModule();
    paymentModule.pay(request.params, function(res) { 
      if(res.success)
      {
        var result = {};
        result.success = true;
        response.success(result);
      }
      else
      {
        var result = {};
        result.success = false;
        result.code = 2;
        response.error(result);
      }
    });
  }
});

// --------------------------------- b64 encoder --------------------------------- //
 var utf8Encode = function(input) {
        input = input.replace(/\r\n/g,"\n");
        var utftext = "";
        for (var n = 0; n < input.length; n++) {
            var c = input.charCodeAt(n);
            if (c < 128)
                utftext += String.fromCharCode(c);
            else if((c > 127) && (c < 2048)) {
                utftext += String.fromCharCode((c >> 6) | 192);
                utftext += String.fromCharCode((c & 63) | 128);
            }
            else {
                utftext += String.fromCharCode((c >> 12) | 224);
                utftext += String.fromCharCode(((c >> 6) & 63) | 128);
                utftext += String.fromCharCode((c & 63) | 128);
          }
        }
        return utftext;
  };

 var b64Encode = function b64Encode(input) {
        var keyStr = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
        var output = "";
        var chr1, chr2, chr3, enc1, enc2, enc3, enc4;
        var i = 0;
        input = utf8Encode(input);
        while (i < input.length) {
            chr1 = input.charCodeAt(i++);
            chr2 = input.charCodeAt(i++);
            chr3 = input.charCodeAt(i++);
            enc1 = chr1 >> 2;
            enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
            enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
            enc4 = chr3 & 63;

            if (isNaN(chr2)) {
                enc3 = enc4 = 64;
            } else if (isNaN(chr3)) {
                enc4 = 64;
           }
          output = output + keyStr.charAt(enc1) + keyStr.charAt(enc2) + keyStr.charAt(enc3) + keyStr.charAt(enc4);
      }
        return output;
  };
// ------------------------------------------------------------ works with older version of parse --------------------------- //
// recepient creation depricated
//#TODO: move to managed accounts
Stripe.Recipients = {};
Stripe.Recipients.create = function(obj, success, error) {
 
 
 var key = "sk_test_0hmo7YaWTsDPo1KouO8hRrEN:sk_test_0hmo7YaWTsDPo1KouO8hRrEN";
 var b64Key = b64Encode(key);

Parse.Cloud.httpRequest({ url: "https://api.stripe.com/v1/recipients",
    method: 'POST',
    headers:{
        'Authorization': "Basic " + b64Key,
        'Accept': 'application/json'
    },
    body:{ 
      name: obj.name,
      type: "individual", 
      card: obj.card,
      email: obj.email
   },
    success: function (httpResponse) {
       success(JSON.parse(httpResponse.text));
    },
    error:function (httpResponse) {
       error(httpResponse);
    }
})
};

Parse.Cloud.define("registerRecepient", function(request, response) {
 var params = JSON.parse(request.body);
 if(!PaymentModule.validateCustomer(params)) {
    response.error("Invalid request params");
  }
  else {
    var obj = {};
    obj.name = request.params.userName;
    obj.type = "individual";
    obj.card = request.params.sourceId;
    obj.email = request.params.userEmail;

      Stripe.Recipients.create(obj
      , function(httpResponse){
        var result = {};
        result.success = true;
        result.tokenId = httpResponse.id;
        response.success(result);
      }, function(httpResponse) {
        var result = {};
        result.success = false;
        result.code = 3;
        response.error(httpResponse);
      });

      /*var recp = Stripe.Recipients.create({
      name: request.params.userName,
      type: "individual",
      card: request.params.sourceId,
      email: request.params.userEmail
      });

      ,{
      success: function(httpResponse) {
       // console.log(httpResponse);
        var result = {};
        result.success = true;
        result.tokenId = httpResponse.id;
        response.success(result);
      },
      error: function(httpResponse) {
          response.error(JSON.stringify({error:3, msg:"Error: " + httpResponse.message+"\n"+
                 "Params:\n"+
                 request.params.token+","+
                 request.params.plan+","+
                 request.params.quantity+
                 "\n"}));
        }
       
      });*/
    }
  });

/*

# charge the Customer instead of the card
Stripe::Charge.create(
    amount: 1000, # in cents
    currency: 'usd',
    customer: customer.id
)

# save the customer ID in your database so you can use it later
save_stripe_customer_id(user, customer.id)

# later
customer_id = get_stripe_customer_id(user)

Stripe::Charge.create(
    amount: 1500, # $15.00 this time
    currency: 'usd',
    customer: customer_id
)*/


