# DSC-Framework

The goal of this framework is to organize DSC config and environmental data files in a way that supports multiple data centers, networks, active directory domains, and product environments- while reusing as much code as possible. The code in this repo is not meant to be plug and play. It's meant to give you ideas on how you can structure and write your DSC configurations in a way that works best for you. 

The code here is a stripped down version of the framework I use in production for structuring my own DSC configs. I have not tested this version, and I **do not** expect it to work. 

The code here is probably not great for beginners; soon I hope to write better documentation either here or on my blog. Until then, some understanding of DSC is probably necessary.

This framework requires and uses elements from multiple sources.

 - Mathieu Buisson's method of [splitting ConfigData](https://mathieubuisson.github.io/merging-configuration-data-files/) files for multiple environments and his [Merge-DscConfigData](https://www.powershellgallery.com/packages/Merge-DscConfigData/1.1.2) module
 - TicketMaster's [NestedConfigs](https://github.com/Ticketmaster/DscExamples/tree/master/NestedConfigs) example
