import requests

def test_routes():
    print("Testing doctor login...")
    r = requests.post("http://localhost:8000/api/v1/auth/login", json={"email": "doctor@aiia.gov.in", "password": "password"})
    if r.status_code == 200:
        doc_token = r.json()["access_token"]
        print("Doctor token obtained.")
        cookies = {"access_token": doc_token}
        
        # Test doctor accessing queue
        r_q = requests.get("http://localhost:8000/portal/queue", cookies=cookies)
        print("Doctor /queue status:", r_q.status_code)
        
        # Test doctor accessing admin
        r_a = requests.get("http://localhost:8000/portal/admin", cookies=cookies)
        print("Doctor /admin status:", r_a.status_code)
    else:
        print("Failed to login doctor:", r.text)

    print("\nTesting admin login...")
    r = requests.post("http://localhost:8000/api/v1/auth/login", json={"email": "admin@aiia.gov.in", "password": "password"})
    if r.status_code == 200:
        adm_token = r.json()["access_token"]
        print("Admin token obtained.")
        cookies = {"access_token": adm_token}
        
        # Test admin accessing admin
        r_a = requests.get("http://localhost:8000/portal/admin", cookies=cookies)
        print("Admin /admin status:", r_a.status_code)
        
        # Test admin accessing queue (should fail since queue is for doctors)
        # Wait, our require_roles function allows admin to access everything if we coded it correctly?
        # "if user.role not in roles and user.role != RoleEnum.admin:"
        # Yes, admins can access doctor routes according to this!
        r_q = requests.get("http://localhost:8000/portal/queue", cookies=cookies)
        print("Admin /queue status:", r_q.status_code)
    else:
        print("Failed to login admin:", r.text)

test_routes()
