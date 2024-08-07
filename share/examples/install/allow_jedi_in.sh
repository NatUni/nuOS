for u in $ADMIN_ACCT $BD_ACCT; do
    mkdir -p "$TRGT/home/$u/.ssh"
    chown -v `stat -f %u:%g "$TRGT/home/$u"` "$TRGT/home/$u/.ssh"
    chmod 700 "$TRGT/home/$u/.ssh"
    cat >> "$TRGT/home/$u/.ssh/authorized_keys" <<'EOF'
ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBACuD4lF7FY0PA9kpoXdnsrsj1+TnpLFDY3forQTN4JHmyvMjUsONnMz7rvofBIBq9yU5iVkGPuiRgeuxGD2YSjhOwEiPd2Y0KRAwNa13IhEIIYQAPhFB0qAqjMdLiBIPBaq0DN8k9FAzyoZdjBT5iZr4oP8tJ/fpNVWc/+l/B9warSpVw== jedi@tty.zion.top
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHyTIh6jLptvCkB/SLhUG69QpLCdrCXr5XSbTYQkhVxu jedi@tty.zion.top
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC7SpqKMlz+ASGG3TQig+n3P3y7k8sffcCGqeJ5oy1rB/QkOxt7ZEmVvmAcu0KKWA+UXaIzl1isn19xQcdjZt3AHcafWqojRQJUBOhB7CpPDlL8t4cWCPQJAsEkbGBi4razcrGBcZubHe6Ld8jEVCMrNcMrD31JIgerjwFm30ttms8WcC8tCc9AOl1IKhp39LqDFQ88Ns3BkY4vEypjqV1duppSPFBaylPZqRnYGwCwXme5Nnv9s1q1LFGFA1YHSqLKXgJbD20zWFux6sT6olDrMfewCOGYrbCjL/82kR5gv3+lDoWUJ04sKZZ3nju7FWUbbzgGt/Z4sl1716/+fXRkprFi1+oAA9IukBO2nMF+bz+1S8htyR07YsBKud67HKG+iio/yzlo1z0Ea69waqKfZpQBrM0jtZbpq90QfTZ3TbQYdGPwSO4IdJijE1hwUwNqYxawb0GO04nDdU4JZ4l6Gj5mZyZpYg0h9+q7J+r8ESAIXR/LZeT1FPkJRBH1x0VfhJW4IvVmgmpi/c0CSoq+TV/uBv3utCFhYPGENw59FEJo4O+HyJBzg9OeAGX6Kp6e04bj1MTvWH45v4jwjUlGLdm3ogVgiUTlzs2TZC3gD/Ctb3QsR3yvqQcDoKrPV/zUvVh/mmYEadC42kH02qpPoP05NXWafEMGQEHvpwVBxw== jedi@tty.zion.top
EOF
    chown -v `stat -f %u:%g "$TRGT/home/$u"` "$TRGT/home/$u/.ssh/authorized_keys"
done
