import datetime
from os import getenv
from flask import Flask, request, json, jsonify, make_response
from flask_restful import Resource, Api, abort, reqparse
from flask_redis import FlaskRedis


app = Flask(__name__)
app.config['REDIS_URL'] = getenv('REDIS_URL', 'redis://localhost:6379/0')

api = Api(app)
redis_store = FlaskRedis(app)

def search_name(name_id):
    if not redis_store.get(name_id):
        abort(404, message="Person {} doesn't exist".format(name_id))

def date_is_valid(value):
    try:
        datetime.datetime.strptime(value, '%Y-%m-%d')
    except ValueError:
        return False

    return True

def create_date_msg(name, date):
    today_date = datetime.date.today()
    converted_date = datetime.datetime.strptime(date, "%Y-%m-%d").date()

    if today_date  == converted_date:
        return "Hello, {}! Happy birthday".format(name)

    birthday_count = converted_date - today_date

    if birthday_count.days == -5:
        return "Hello, {}! Your birthday is in 5 days".format(name)

    return date

class UserDate(Resource):
    def get(self, name_id):
        search_name(name_id)
        r = redis_store.get(name_id)

        return jsonify(message=create_date_msg(name_id,r))

    def put(self, name_id):

        if request.headers['Content-Type'] == 'application/json':
           js = json.dumps(request.json)
        else:
           return "unsupported Media Type", 400

        jsload = json.loads(js)
        name_date = jsload['dateOfBirth']

        if date_is_valid(name_date):
           r = redis_store.set(name_id, name_date)
           return make_response('',201)
        else:
            msg = jsonify(message="Date is incorrect, should be YYYY-MM-DD")
            return make_response(msg, 400)

api.add_resource(UserDate, '/<string:name_id>')

if __name__ == '__main__':
    app.run(host='0.0.0.0',port=5000)
