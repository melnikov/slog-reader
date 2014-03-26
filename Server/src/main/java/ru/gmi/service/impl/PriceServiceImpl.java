package ru.gmi.service.impl;

import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;

import ru.gmi.dao.impl.GenericDAOImpl;
import ru.gmi.domain.Price;
import ru.gmi.service.PriceService;

/**
 * Price service implementation.
 * @author Andrey Polikanov
 *
 */
@Service
@Repository
public class PriceServiceImpl extends GenericDAOImpl<Price> 
    implements PriceService {

}
