#!/bin/bash



USERNAME=$1

if [ -z $USERNAME ]; then
        echo "please enter the username"

else
         CHECKUSER=`ldapsearch -x -H ldap://localhost -b uid=$USERNAME,ou=inapp,ou=Users,dc=inapp,dc=com | grep "uid: " | awk '{print $2}'`
         if [[ "$CHECKUSER" = "$USERNAME" ]]; then
                 echo "User $USERNAME already exists"
         else
                 while true; do

                         read -p "Enter the last name: " SNAME
                         read -p "Enter the dislpay name: " DISPLAY
                         read -p "Enter the employee number: " EMPLOYEE
                         read -p "Enter the email id: " EMAIL
                         read -p "Enter the user password: " PASSWORD
                         if [[ -z $SNAME ]] || [[ -z $EMAIL ]] || [[ -z $PASSWORD ]] || [[ -z $EMPLOYEE ]] || [[ -z $DISPLAY ]]; then
                                 echo "Empty entry! please fill again"
                         else
                                 break;
                         fi
                done

                 cat << EOF > /home/inapp/ldif/$USERNAME.ldif
dn: uid=$USERNAME,ou=inapp,ou=Users,dc=inapp,dc=com
uid: $USERNAME
cn: $USERNAME
sn: $SNAME
mail: $EMAIL
ou: intranet
ou: dotnetproject
employeeNumber: $EMPLOYEE
displayName: $DISPLAY
objectclass: person
objectclass: organizationalperson
objectclass: inetorgperson
objectclass: posixaccount
objectclass: top
objectclass: shadowaccount
userpassword: {crypt}x
shadowlastchange: 17449
shadowmin: 0
shadowmax: 99999
shadowwarning: 7
loginshell: /bin/nologin
uidnumber: 1000
gidnumber: 1000
homedirectory: /home/$USERNAME
EOF
                 echo "Adding user"
                 ldapadd -x -W -D "cn=admin,dc=inapp,dc=com" -f /home/inapp/ldif/$USERNAME.ldif -H ldap://localhost
                 echo "Adding credentials"
                 ldappasswd -s $PASSWORD -W -D "cn=admin,dc=inapp,dc=com" -x "uid=$USERNAME,ou=inapp,ou=Users,dc=inapp,dc=com" -H ldap://localhost
                 echo "$USERNAME added to LDAP server"
         fi

fi
