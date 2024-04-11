from flask import Blueprint, jsonify, request

health_bp = Blueprint("health", __name__)

@health_bp.route('/health', methods=['GET'])
def health_check():
    response = {
        'result': 'Healthy',
        'error': False
    }
    return jsonify(response), 200