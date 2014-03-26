package ru.gmi.filters;

import java.util.List;

/**
 * Encapsulates results of some objects querying.
 * @author Andrey Polikanov
 *
 * @param <T>
 */
public class FilterResult<T> {
    
    private int unfilteredNumber;
    
    private int filteredNumber;
    
    private List<T> resultList;

    public int getUnfilteredNumber() {
        return unfilteredNumber;
    }

    public void setUnfilteredNumber(int unfilteredNumber) {
        this.unfilteredNumber = unfilteredNumber;
    }

    public int getFilteredNumber() {
        return filteredNumber;
    }

    public void setFilteredNumber(int filteredNumber) {
        this.filteredNumber = filteredNumber;
    }

    public List<T> getResultList() {
        return resultList;
    }

    public void setResultList(List<T> resultList) {
        this.resultList = resultList;
    }
    
}
