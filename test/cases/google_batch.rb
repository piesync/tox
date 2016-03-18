labelrel = -> (other) {
  {
    label: at('label'),
    rel: at('rel')
  }.merge(other)
}

el('feed', mel('entry', {
    etag: at('etag'),
    batch_id: el('batch:id', text),
    batch_type: el('batch:operation', at('type')),
    batch_status: el('batch:status', {
      code: at('code'),
      reason: at('reason')
    }),
    batch_interrupted_reason: el('batch:interrupted', at('reason')),
    id: el('id', text),
    categories: mel('category', {
      scheme: at('scheme'),
      term: at('term')
    }),
    name: el('gd:name', {
      first_name: el('gd:givenName', text),
      last_name: el('gd:familyName', text),
      prefix: el('gd:namePrefix', text),
      additional: el('gd:additionalName', text),
      suffic: el('gd:nameSuffix', text),
      full_name: el('gd:fullName', text)
    }),
    nickname: el('gContact:nickname', text),
    birthday: el('gContact:birthdate', text),
    events: mel('gContact:event', labelrel.({
      date: el('gd:when', at('startTime'))
    })),
    save_as: el('gContact:fileAs', text),
    updated_at: el('updated', text),
    extra_info: el('content', text),
    links: mel('link', labelrel.({
      href: at('href')
    })),
    emails: mel('gd:email', labelrel.({
      primary: at('primary'),
      email: at('address')
    })),
    numbers: mel('gd:phoneNumber', labelrel.({
      number: text
    })),
    messengers: mel('gd:im', labelrel.({
      email: at('address'),
      service: at('protocol')
    })),
    companies: mel('gd:organization', labelrel.({
      name: el('gd:orgName', text),
      title: el('gd:orgTitle', text)
    })),
    addresses: mel('gd:structuredPostalAddress', labelrel.({
      street: el('gd:street', text),
      neighborhood: el('gd:neighborhood', text),
      pobox: el('gd:pobox', text),
      zip: el('gd:postcode', text),
      city: el('gd:city', text),
      state: el('gd:region', text),
      country: el('gd:country', text),
      formatted_address: el('gd:formattedAddress', text)
    })),
    deleted: el('deleted', text),
    relations: mel('gContact:relation', labelrel.({
      value: text
    })),
    custom_fields: mel('gContact:userDefinedField', {
      label: at('key'),
      value: at('value')
    }),
    websites: mel('website', labelrel.({
      url: at('href')
    })),
    groups: mel('gContact:groupMembershipInfo', {
      group_url: at('href'),
      deleted: at('deleted')
    })
}), {
  nil        => 'http://www.w3.org/2005/Atom',
  'gContact' => 'http://schemas.google.com/contact/2008',
  'gd'       => 'http://schemas.google.com/g/2005',
  'batch'    => 'http://schemas.google.com/gdata/batch'
})
