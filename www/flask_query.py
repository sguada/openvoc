"""The main routine that starts a imagenet demo."""
import datetime
import flask
from flask import Flask, url_for, request
import gflags
import logging
import numpy as np
import os
from PIL import Image as PILImage
from skimage import io
import cStringIO as StringIO
import socket
import sys
import time
from tempfile import mkstemp
import urllib
import util
from werkzeug import secure_filename
import yaml

# tornado
from tornado.wsgi import WSGIContainer
from tornado.httpserver import HTTPServer
from tornado.ioloop import IOLoop

UPLOAD_FOLDER = '/tmp/openvoc'
ALLOWED_IMAGE_EXTENSIONS = set(['png', 'bmp', 'jpg', 'jpe', 'jpeg', 'gif'])

gflags.DEFINE_string('upload_folder', UPLOAD_FOLDER, 'The folder to store the uploaded images.')
FLAGS = gflags.FLAGS

# Obtain the flask app object
app = Flask(__name__)

@app.route('/')
def index():
    return flask.render_template('query.html',
                                 has_result=False)

@app.route('/classify_url', methods=['GET'])
def classify_url():
    # classify image using the URL
    imageurl = request.args.get('imageurl', '')
    try:
        string_buffer = StringIO.StringIO(
            urllib.urlopen(imageurl).read())
        image = io.imread(string_buffer)
        handle, filename = mkstemp(suffix='.png', prefix=os.path.join(FLAGS.upload_folder, ''))
        io.imsave(filename, image)
    except Exception as err:
        # For any exception we encounter in reading the image, we will just
        # not continue.
        logging.info('URL Image open error: %s', err)
        return flask.render_template('query.html',
                                     has_result=True,
                                     result=(False, 'Cannot open image from URL.'))
    logging.info('Image: %s', imageurl)
    result, outfname = classify_image(filename)
    outimage = io.imread(outfname)
    return flask.render_template('query.html',
                                 has_result=True,
                                 result=result,
                                 imagesrc=embed_image_html(outimage))

@app.route('/classify_upload', methods=['POST'])
def classify_upload():
    # classify image using the image name
    try:
        # We will save the file to disk for possible data collection.
        imagefile = request.files['imagefile']
        filename = os.path.join(FLAGS.upload_folder,
                                str(datetime.datetime.now()).replace(' ', '_') + \
                                secure_filename(imagefile.filename))
        imagefile.save(filename)
        logging.info('Saving to %s.', filename)
        image = io.imread(filename)
    except Exception as err:
        logging.info('Uploaded mage open error: %s', err)
        return flask.render_template('query.html',
                                     has_result=True,
                                     result=(False, 'Cannot open uploaded image.'))
    result, outfname = classify_image(filename)
    outimage = io.imread(outfname)
    return flask.render_template('query.html',
                                 has_result=True,
                                 result=result,
                                 imagesrc=embed_image_html(outimage))

@app.route('/run_query', methods=['POST'])
def run_query():
    result, outfname = text_query(request.form['textquery'])
    outimage = io.imread(outfname)
    return flask.render_template('query.html',
                                 has_result=True,
                                 result=result,
                                 imagesrc=embed_image_html(outimage))

def text_query(query):
    try:
        starttime = time.time()
        # do stuff here
        conn = util.Connection('web')
        conn.open()
        struct = {}
        struct["from"] = 'web'
        struct["to"] = 'matlab'
        struct["subject"] = 'query'
        struct["query"] = query
        conn.send(struct)
        print "Now listening for some stuff"
        info = conn.recv()

        # placeholder results
        scores = [1] # placeholder
        indices = [0] # placeholder
        predictions = [query] # placeholder
        # In addition to the prediction text, we will also produce the length
        # for the progress bar visualization.
        max_score = scores[indices[0]]
        meta = [(p, '%.5f' % scores[i]) for i, p in zip(indices, predictions)]
        logging.info('result: %s', str(meta))
    except Exception as err:
        logging.info('Classification error: %s', err)
        return (False, 'Oops, something wrong happened with classifying the'
                       ' image. Maybe try another one?'), None
    # If everything is successful, return the results
    endtime = time.time()
    print info['display']
    return (True, meta, '%.3f' % (endtime-starttime)), info['display']

def embed_image_html(image):
    """Creates an image embedded in HTML base64 format."""
    image_pil = PILImage.fromarray(image)
    string_buf = StringIO.StringIO()
    image_pil.save(string_buf, format='png')
    data = string_buf.getvalue().encode('base64').replace('\n', '')
    return 'data:image/png;base64,' + data

@app.route('/about')
def about():
    return flask.render_template('about.html')

def allowed_file(filename):
    return ('.' in filename and
            filename.rsplit('.', 1)[1] in ALLOWED_IMAGE_EXTENSIONS)

def classify_image(filename):
    # let's classify the image.
    try:
        starttime = time.time()
        # do stuff here
        conn = util.Connection('web')
        conn.open()
        struct = {}
        struct["from"] = 'web'
        struct["to"] = 'matlab'
        struct["subject"] = 'image'
        struct["image"] = filename
        conn.send(struct)
        print "Now listening for some stuff"
        info = conn.recv()

        # placeholder results
        scores = [1] # placeholder
        indices = [0] # placeholder
        predictions = [filename] # placeholder
        # In addition to the prediction text, we will also produce the length
        # for the progress bar visualization.
        max_score = scores[indices[0]]
        meta = [(p, '%.5f' % scores[i]) for i, p in zip(indices, predictions)]
        logging.info('result: %s', str(meta))
    except Exception as err:
        logging.info('Classification error: %s', err)
        return (False, 'Oops, something wrong happened with classifying the'
                       ' image. Maybe try another one?'), None
    # If everything is successful, return the results
    endtime = time.time()
    return (True, meta, '%.3f' % (endtime-starttime)), info['display']

if __name__ == '__main__':
    gflags.FLAGS(sys.argv)
    # try to make the upload directory.
    try:
        os.makedirs(FLAGS.upload_folder)
    except Exception as err:
        pass
    logging.getLogger().setLevel(logging.INFO)
    #app.net = imagenet.DecafNet(net_file=FLAGS.net_file, meta_file=FLAGS.meta_file)
    #app.run(host='0.0.0.0')
    http_server = HTTPServer(WSGIContainer(app))
    http_server.listen(5001)
    IOLoop.instance().start()
