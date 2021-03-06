test_name "verifies that puppet resource creates a user and assigns the correct group"

user  = "test-user-#{Time.new.to_i}"
group = "test-user-#{Time.new.to_i}-group"

agents.each do |host|
    step "user should not exist"
    on host, "if getent passwd #{user}; then userdel #{user}; fi"

    step "group should exist"
    on host, "if ! getent group #{group}; then groupadd #{group}; fi"

    step "create user with group"
    run_puppet_on host, :resource, 'user', user, 'ensure=present', "gid=#{group}"

    step "verify the group exists and find the gid"
    on(host, "getent group #{group}") do
        gid = stdout.split(':')[2]

        step "verify that the user has that as their gid"
        on(host, "getent passwd #{user}") do
            got = stdout.split(':')[3]
            fail_test "wanted gid #{gid} but found #{got}" unless gid == got
        end
    end

    step "clean up after the test is done"
    run_puppet_on host, :resource, 'user', user, 'ensure=absent'
    run_puppet_on host, :resource, 'group', group, 'ensure=absent'
end
