select p.websiteCode,p.product, d.price,d.percentOffMSRP,d.quantity,d.dealdurationinminutes,d.timeEnter from BackcountryProducts p, BackcountryProductDetails d where p.ProductEntrykey=d.ProductEntrykey;