const mongoose = require('mongoose');
const connectDB = async function () {
    try {
        const conn = await mongoose.connect("mongodb://127.0.0.1/huyhunhngc", {
            useNewUrlParser: true,
            useUnifiedTopology: true,
            useFindAndModify: false
        });
        console.log(`MongoDB Connected: ${conn.connection.port}`)

    } catch (err) {
        console.log(err)
        process.exit(1)
    }
}
module.exports = connectDB