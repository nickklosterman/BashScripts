// db.deal.distinct('productTitle').forEach(function(product){
//     var count=db.deal.find({productTitle:product}).count();
//     if (count > 5 ) {
//         print(product,count);
//     }
// });

print("--SAC--");
db.deal.find({site:"SAC"},{name:1,price:1}).sort({_id:-1}).limit(5).skip(1).forEach(function(result){
print(result.name+" : "+result.price)
});
print("--CL--");
db.deal.find({site:"CL"},{productTitle:1,price:1}).sort({_id:-1}).limit(5).skip(1).forEach(function(result){
print(result.productTitle+" : "+result.price)
});
print("--WM--");
db.deal.find({site:"WM"},{productTitle:1,price:1}).sort({_id:-1}).limit(5).skip(1).forEach(function(result){
print(result.productTitle+" : "+result.price)
});


