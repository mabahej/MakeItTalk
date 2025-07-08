# app.py
from flask import Flask, request, jsonify
import base64, os, tempfile
from makeitalk.inference import MakeItTalkInfer  # model entrypoint

app = Flask(__name__)
infer = MakeItTalkInfer()

@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json()
    img_bytes = base64.b64decode(data['image'])
    wav_path = data.get('audio_path')  # GCS path to speech.wav
    
    # save image to temp
    img_file = tempfile.NamedTemporaryFile(suffix='.png', delete=False)
    img_file.write(img_bytes); img_file.flush()
    
    # run model: returns path to generated video
    out_video = infer.run(image_path=img_file.name,
                          audio_path=wav_path,
                          output_dir=tempfile.gettempdir())
    
    # return base64 video
    with open(out_video, 'rb') as f:
        vid_b64 = base64.b64encode(f.read()).decode('utf-8')
    return jsonify({'video': vid_b64})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
