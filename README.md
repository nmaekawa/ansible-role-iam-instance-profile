cloudwatch
=========
Creates new aws iam instance profile, based on list of managed policies json
documents. Instance-name must not yet exist, otherwise it's an error. Role-name
might exist, and if so, existing role is used.

Note that list of policies will be attached to role, if role already exists.

Policies are created based on the name of the filename of json document. If a
policy name already exists, it is used, without checking if contents of
existing policy and intended policy are the same.


requirements
------------

Tasks are performed locally, and requires awscli to be installed.


example playbook
----------------

    - hosts: all
      import_role:
          name: ansible-role-iam-instance-profile
      vars:
          aws_role_name: myRoleName
          instance_profile_name: myInstanceProfileName
          policy_document_fullpath_list:
            - "/some/path/to/policy/json/document/thisIsTheNameOfPolicy1.json"
            - "/some/path/to/policy/json/document/thisIsTheNameOfPolicy2.json"
            - "/some/path/to/policy/json/document/thisIsTheNameOfPolicy3.json"
            - "/some/path/to/policy/json/document/thisIsTheNameOfPolicy4.json"


license
-------

MIT


