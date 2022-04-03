#unmatch statement
db.ns_channel_statements.find({
    w_date: ISODate("2022-01-03"),
    route: 'Wechat'
    
    })

    settle: {'$ne':1}

db.ns_channel_statements.find({pay_order_id: ObjectId("61d1ed83be1d2d668efdc480")})

db.ns_channel_statements.aggregate([
    {$match: {w_date: ISODate("2022-01-01")}},
    {$group: {
      _id: "$route",
      statement_count: {'$sum': 1},
    }}
])