from flask import Flask, render_template, jsonify
import json
import os

app = Flask(__name__)

# Define the route for the homepage (dashboard)
@app.route('/')
def home():
    return render_template('index.html')  # Ensure this exists in the templates folder

# Define the route to fetch system information from the system_info.json file
@app.route('/api/system_info')
def system_info():
    try:
        # Path to the system_info.json file
        json_file_path = '/mnt/c/project/system_info.json'
        
        # Check if the file exists before trying to open it
        if os.path.exists(json_file_path):
            # Read the system info from the JSON file
            with open(json_file_path, 'r') as file:
                system_data = json.load(file)
            return jsonify(system_data)  # Return the system data as JSON response
        else:
            return jsonify({'error': 'system_info.json file not found'}), 404

    except Exception as e:
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    app.run(debug=True)

