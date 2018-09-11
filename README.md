cloudwatch
=========
Creates new aws iam instance profile, based on list of managed policies json
documents. Instance-name must not yet exist, otherwise it's an error. Role-name
might exist, and if so, existing role is used.


requirements
------------

Tasks are performed locally, and requires awscli and aws proper credentials to
be installed and setup.

`aws_role_name` aws role-name to add to instance profile being created; if
role-name already exists, it is used. Note that the list of policies will be
attached to the existing role, without any checks.

`instance_profile_name` name for instance profile being created; must not exist
otherwise it's an error.

`policy_document_fullpath_list` list of fullpath filenames for json documents
describing iam managed policies for a role. Policies are created and named
based on the name of the filename (minus `.json` extension; assumes the
extension of filename _is_ `.json`). If policy name already exists, then it is
used as is, without checking contents of existing policy.

`instance_id_to_associate` instance-id of ec2 instance to be associated to
instance profile being created. This is a separate step, see example below.


example playbook
----------------

    - hosts: all
      tasks:
        - import_role:
            name: ansible-role-iam-instance-profile
          vars:
            aws_role_name: myRoleName
            instance_profile_name: myInstanceProfileName
            policy_document_fullpath_list:
                - "/some/path/to/policy/json/document/thisIsTheNameOfPolicy1.json"
                - "/some/path/to/policy/json/document/thisIsTheNameOfPolicy2.json"
                - "/some/path/to/policy/json/document/thisIsTheNameOfPolicy3.json"
                - "/some/path/to/policy/json/document/thisIsTheNameOfPolicy4.json"

        # if you want to associate the instance profile to an ec2
        - include_tasks: ansible-role-iam-instance-profile/tasks/associate_iam_instance_profile.yml
          vars:
            instance_id_to_associate: i-1234567890
            instance_profile_name: myInstanceProfileName

license
-------

MIT


