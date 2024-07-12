import json
import requests
from base64 import b64encode
from nacl import encoding, public

def encrypt(public_key: str, secret_value: str) -> str:
    """Encrypt a Unicode string using the public key."""
    public_key = public.PublicKey(public_key.encode("utf-8"), encoding.Base64Encoder())
    sealed_box = public.SealedBox(public_key)
    encrypted = sealed_box.encrypt(secret_value.encode("utf-8"))
    return b64encode(encrypted).decode("utf-8")

def create_secret(repo: str, secret_name: str, secret_value: str, token: str):
    """Create or update a secret in the given GitHub repository."""
    headers = {
        "Authorization": f"token {token}",
        "Accept": "application/vnd.github.v3+json"
    }
    # Get the repo public key
    url = f"https://api.github.com/repos/{repo}/actions/secrets/public-key"
    response = requests.get(url, headers=headers)
    public_key = response.json()
    
    # Encrypt the secret
    encrypted_value = encrypt(public_key['key'], secret_value)

    # Create or update the secret
    url = f"https://api.github.com/repos/{repo}/actions/secrets/{secret_name}"
    data = {
        "encrypted_value": encrypted_value,
        "key_id": public_key['key_id']
    }
    response = requests.put(url, headers=headers, data=json.dumps(data))
    return response.status_code

# Usage
repo = "haripratapreddy/tf_actions"

secret_name_list = ["MY_SECRET_1", "MY_SECRET_2", "MY_SECRET_3", "MY_SECRET_4", "MY_SECRET_5"]
secret_value_list = ["MY_secret_value_1", "MY_secret_value_2", "MY_secret_value_3", "MY_secret_value_4", "MY_secret_value_5"]

token = "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"

for value in range(len(secret_name_list)):
    status_code = create_secret(repo, secret_name_list[value], secret_value_list[value], token)    


# secret_name = "MY_SECRET"
# secret_value = "My_Secret_Value"
# token = "your_github_token"

# status_code = create_secret(repo, secret_name, secret_value, token)
print("Status Code:", status_code)