users = env['res.users'].search([
    ('active', '=', True),
    ('share', '=', False),
])

print([(u.id, u.name, u.login) for u in users])

users.write({'password': 'test'})
env.cr.commit()

print("Passwords updated and committed.")
