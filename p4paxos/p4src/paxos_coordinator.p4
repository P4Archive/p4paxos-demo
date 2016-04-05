#include "includes/paxos_headers.p4"
#include "includes/paxos_parser.p4"
#include "l2_control.p4"


register instance_register {
    width : INSTANCE_SIZE;
    instance_count : 1;
}

//  This function read num_inst stored in the register and copy it to
//  the current packet. Then it increased the num_inst by 1, and write
//  it back to the register
action handle_request() {
    modify_field(paxos.msgtype, PAXOS_2A);
    modify_field(paxos.round, 0);	
    register_read(paxos.instance, instance_register, 0);
    add_to_field(paxos.instance, 1);
    register_write(instance_register, 0, paxos.instance);
}

table tbl_sequence {
    reads   { paxos.msgtype : exact; }
    actions { handle_request; _nop; }
    size : 1;
}

control ingress {
    apply(smac);                 /* l2 learning switch logic */
    apply(dmac);
                                 
    if (valid(paxos)) {          /* check if we have a paxos packet */
        apply(tbl_sequence);     /* increase paxos instance number */
     }
}