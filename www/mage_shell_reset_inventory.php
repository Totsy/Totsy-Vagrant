<?php
/**
 * Author: Zach Selby
 * Date: Mar 11, 2013
 * Time: 09:02:07 AM
 *
 * Mage_Shell script that sets up initial dev db events and inventory for testing
 *
 *
 */

require_once 'abstract.php';

class Totsy_Shell_Dev_Inventory extends Mage_Shell_Abstract
{
    var $categoryEvents;
    var $productStocks;
    var $quiet = false;

    const PRODUCT_STOCK_QTY_DEFAULT = 10;
    const PRODUCT_STOCK_QTY_ZERO = 0;
    const CATEOGORY_EXPIRED_DEFAULT_ID = 7685; //Canvas People

    /**
     * Run script
     *
     */
    public function run()
    {
        if ($this->getArg('quiet')) {
            $this->quiet = true;
        }

        if ($this->getArg('runall')) {
            $this->activateAllCategoryEvents();
            $this->expireOneCategoryEvent();
            $this->resetStock();
            $this->rebuildCategorySortentry();
        } elseif ($this->getArg('activateevents')) {
            $this->activateAllCategoryEvents();
        } elseif ($this->getArg('categorysort')) {
            $this->rebuildCategorySortentry();
        } elseif ($this->getArg('resetstock')) {
            $this->resetStock();
        } elseif ($this->getArg('expireone')) {
            $this->expireOneCategoryEvent();
        // help
        } else {
            echo $this->usageHelp();
        }
    }

    private function getCategoryEvents() {
        if ( !is_array($this->categoryEvents) || count($this->categoryEvents) < 1 ) {
            $this->categoryEvents = Mage::getModel('catalog/category')
                ->getCollection()
                ->addAttributeToSelect('name')
                ->addAttributeToSelect('level')
                ->addAttributeToSelect('is_active')
                ->addAttributeToSelect('event_start_date')
                ->addAttributeToSelect('event_end_date');

            $this->categoryEvents->load();
        }

        return $this->categoryEvents;
    }

    private function getProductStocks() {
        if ( !is_array($this->productStocks) || count($this->productStocks) < 1 ) {
            $this->productStocks = Mage::getModel('cataloginventory/stock_item')
                ->getCollection();

            $this->productStocks->load();
        }

        return $this->productStocks;
    }

    private function activateAllCategoryEvents()
    {
        $storeDateNow   = Mage::getModel('core/date')->date();
        $storeDateLater = Mage::getModel('core/date')->date(null, strtotime($storeDateNow . " +7 days"));

        $categories = $this->getCategoryEvents();

        foreach ($categories as $category) {
            $category->load();
            if ($category->getEventStartDate() !== null && $category->getLevel() >= 3) {
                $category->setEventStartDate($storeDateNow);
                $category->setEventEndDate($storeDateLater);
                $category->setIsActive(1);
                $this->log("Activating event " . $category->getName() . "...");
                $category->save();
                $this->log("Done.\n");
            }
        }

        $this->log("\n");
    }

    private function expireOneCategoryEvent()
    {
        $storeDateAlreadyEnd    = Mage::getModel('core/date')->date(null, strtotime($storeDateNow . " -1 days"));
        $storeDateAlreadyStart  = Mage::getModel('core/date')->date(null, strtotime($storeDateNow . " -2 days"));

        $deactivatedCategoryEvent = Mage::getModel('catalog/category')
            ->load(self::CATEOGORY_EXPIRED_DEFAULT_ID);

        $deactivatedCategoryEvent->setIsActive(0);
        $deactivatedCategoryEvent->setEventEndDate($storeDateAlreadyEnd);
        $deactivatedCategoryEvent->setEventStartDate($storeDateAlreadyStart);
        $this->log("Expiring event " . $deactivatedCategoryEvent->getName() . "...");
        $deactivatedCategoryEvent->save();
        $this->log("Done.\n");
        $this->log("\n");
    }

    private function resetStock($destockSomeItems = true) {
        $productStocks = $this->getProductStocks();

        $this->log("Enabling stock for all products...");

        foreach ($productStocks as $productStock) {
            if ($productStock->getIsInStock() == false || $productStock->getQty() < 1) {
                $emptyStock = false;

                if ($destockSomeItems == true && isset($hasUpdatedStock) && $hasUpdatedStock == true) {
                    $emptyStock = rand(1,5) == 1 ? true : false;
                }

                if ($emptyStock) {
                    $productStock->setIsInStock(0);
                    $productStock->setQty(self::PRODUCT_STOCK_QTY_ZERO);
                } else {
                    $productStock->setIsInStock(1);
                    $productStock->setQty(self::PRODUCT_STOCK_QTY_DEFAULT);
                }

                $productStock->save();
                $hasUpdatedStock = true;
            }
        }

        $this->log("Done.\n\n");
    }

    private function rebuildCategorySortentry() {
        $storeId = Mage_Core_Model_App::ADMIN_STORE_ID;

        $sortentry = Mage::getModel('categoryevent/sortentry')->loadCurrent($storeId);

        if ($sortentry->getId()) {
            $this->log("Rebuilding most recent sortentry...");
            $sortentry->rebuild();
            $this->log("Done.\n\n");
        } else {
            $this->log("Could not load sortentry.\n\n");
        }
    }

    private function log($msg) {
        if ($this->quiet != true) {
            echo $msg;
        }
    }

    /**
     * Retrieve Usage Help Message
     *
     */
    public function usageHelp()
    {
        return <<<USAGE
Usage:  php -f devinventory.php [options]
        php -f devinventory.php help

  activateevents    Set all event start dates to yesterday, and end dates to one week away
  categorysort      Rebuild category sortentry
  resetstock        Set all products to in stock, with default quantity ({self::DEFAULT_PRODUCT_STOCK_QTY})

  runall            Run all of the above
  help

USAGE;
    }

}

$shell = new Totsy_Shell_Dev_Inventory();
$shell->run();
