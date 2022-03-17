db.merchants.aggregate([
{
    $group: {
        _id: "$_type",
        cnt: {
            $sum: 1 
        } 
     }
}
])