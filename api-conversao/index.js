const express = require('express')
const app = express()

app.get('/', (req, res) => {
    return res.send('ok\n')
})

app.listen(8080, () => {
    console.log('server on')
})