srsly ${NS_LOOKUP_IP6-} && ns_ip4= || ns_ip4=y
sister nu_ns_cache -C "$TRGT" -s ${ns_ip4:+-4}
