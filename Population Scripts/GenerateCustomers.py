import json
import random
import secrets
import string

def read_json(file):
    with open('Resources/' + file + '.json') as f:
        return json.loads(f.read())

def generate_number(lower_bound, upper_bound):
    return random.randint(lower_bound, upper_bound)

class Name():
    def __init__(self):
        self.firstname = self.generate_firstname()
        self.lastname = self.generate_lastname()
        self.contact_number = self.generate_contact_number()
        self.email = (self.firstname + '.' + self.lastname + '@' + self.generate_email()).lower()

    def generate_firstname(self):
        return str(random.choice(read_json('firstnames')))

    def generate_lastname(self):
        return str(random.choice(read_json('surnames')))

    def generate_contact_number(self):
        return '04' + str(generate_number(0,99999999)).zfill(8)

    def generate_email(self):
        return str(random.choice(read_json('emailproviders')))

class Password():
    def __init__(self):
        self.password = self.generate_password()
    
    def generate_password(self):
        return ''.join(secrets.choice(string.ascii_letters + string.digits) for i in range(64))

class Address():
    def __init__(self):
        self.address_number = self.generate_address_number()
        self.address_name = self.generate_address_name().title()
        self.address_suffix = self.generate_address_suffix().title()
        self.postcode = self.generate_postcode()
        self.city = self.generate_city().title()
        self.state = self.generate_state()
        self.country = "Australia"
    
    def generate_address_number(self):
        return generate_number(1,9999)

    def generate_address_name(self):
        return str(random.choice(read_json('common')))
    
    def generate_address_suffix(self):
        return str(random.choice(read_json('addresssuffixes')))

    def generate_postcode(self):
        return generate_number(1000,9999)

    def generate_city(self):
        return str(random.choice(read_json('cities')))
    
    def generate_state(self):
        return str(random.choice(read_json('states')))

class Record():
    def __init__(self):
        self.details = Name()
        self.password = Password()
        self.address = Address()

def generate_sql(number_of_records):
    for i in range(1, number_of_records):
        record = Record()

        password_sql = """
        INSERT INTO CustomerPassword (
            [CustomerID],
            [Password])
 	    VALUES(
 	        {},
            '{}');""".format(
                i,
                record.password.password)
        
        address_sql = """
        INSERT INTO CustomerAddress (
            [AddressID],
            [StreetNum],
            [StreetName],
            [Postcode],
            [City],
            [State],
            [Country])
 	    VALUES(
            {},
 	        {},
            '{}',
            '{}',
            '{}',
            '{}',
            '{}');""".format(
                i,
                record.address.address_number,
                record.address.address_name,
                record.address.postcode,
                record.address.city,
                record.address.state,
                record.address.country)

        customer_sql = """
        INSERT INTO Customer (
            [fName],
            [lName],
            [ContactNumber],
            [Email],
            [PasswordID],
            [AddressID])
 	    VALUES(
 	        '{}',
            '{}',
            '{}',
            '{}',
            {},
            {});""".format(
                record.details.firstname,
                record.details.lastname,
                record.details.contact_number,
                record.details.email,
                i,
                i)

        with open('Generated SQL Scripts/customer_generation.sql',"a") as f:
            f.write(password_sql)
            f.write("\n")
            f.write(address_sql)
            f.write("\n")            
            f.write(customer_sql)
            f.write("\n")

if __name__ == '__main__':
    generate_sql(100)